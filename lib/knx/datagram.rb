# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    DatagramBuilder = Struct.new(:header, :cemi, :source_address, :destination_address, :data, :action_type) do

        def to_binary_s
            resp = if @cemi.apply_apci(self.action_type, self.data) && self.data
                @cemi.data_length = self.data.length

                if self.data.length > 1
                    self.data[1..-1].pack('C')
                else
                    String.new
                end
            elsif present?(self.data)
                @cemi.data_length = self.data.length
                self.data.pack('C')
            else
                @cemi.data_length = 0
                String.new
            end

            @cemi.source_address      = self.source_address.to_i
            @cemi.destination_address = self.destination_address.to_i

            # 17 == header + cemi
            @header.request_length = resp.bytesize + 17
            "#{@header.to_binary_s}#{@cemi.to_binary_s}#{resp}"
        end


        protected


        def present?(data)
            !(data.nil? || data.empty?)
        end

        def initialize(address = nil, options = nil)
            super()
            return unless address

            @address = parse(address)

            @cemi = CEMI.new
            @cemi.msg_code = MsgCode[options[:msg_code]]
            @cemi.is_standard_frame = true
            @cemi.no_repeat = options[:no_repeat]
            @cemi.broadcast = options[:broadcast]
            @cemi.priority = Priority[options[:priority]]

            @cemi.is_group_address = @address.is_group?
            @cemi.hop_count = options[:hop_count]

            @header = Header.new
            @header.version = 0x10
            if options[:request_type]
                @header.request_type = RequestTypes[options[:request_type]]
            else
                @header.request_type = RequestTypes[:routing_indication]
            end

            self.header = @header
            self.cemi = @cemi
            self.source_address = IndividualAddress.parse_friendly('0.0.1')
            self.destination_address = @address

            @cemi.source_address      = self.source_address.to_i
            @cemi.destination_address = self.destination_address.to_i
        end

        def parse(address)
            result = address.split('/')
            if result.length > 1
                if result.length == 3
                    GroupAddress.parse_friendly(address)
                else
                    GroupAddress2Level.parse_friendly(address)
                end
            else
                IndividualAddress.parse_friendly(address)
            end
        end
    end

    class ActionDatagram < DatagramBuilder
        def initialize(address, data_array, options)
            super(address, options)

            # Set the protocol control information
            self.action_type = @address.is_group? ? :group_write : :individual_write
            @cemi.apply_apci(self.action_type, data_array)
            @cemi.tpci = TpciType[:unnumbered_data]

            if present? data_array
                @cemi.data_length = data_array.length
                self.data = data_array
            end
        end
    end

    class StatusDatagram < DatagramBuilder
        def initialize(address, options)
            super(address, options)

            # Set the protocol control information
            self.action_type = @address.is_group? ? :group_read : :individual_read
            @cemi.apply_apci(self.action_type)
            @cemi.tpci = TpciType[:unnumbered_data]
        end
    end

    class ResponseDatagram < DatagramBuilder
        def initialize(raw_data, options)
            super()

            @header = Header.new
            @header.read(raw_data[0..5])

            @cemi = CEMI.new
            @cemi.read(raw_data[6..16])

            self.header = @header
            self.cemi = @cemi

            self.data = raw_data[17..(@header.request_length - 1)].bytes
            if @cemi.data_length > self.data.length
                self.data.unshift @cemi.data
                self.action_type = ActionType[@cemi.apci]
            else
                acpi = @cemi.data | (@cemi.apci << 6)
                self.action_type = ActionType[acpi] || ActionType[@cemi.apci]
            end

            self.source_address = IndividualAddress.parse(@cemi.source_address.to_i)

            if @cemi.is_group_address == 0
                self.destination_address = IndividualAddress.parse(@cemi.destination_address.to_i)
            elsif options[:two_level_group]
                self.destination_address = GroupAddress2Level.parse(@cemi.destination_address.to_i)
            else
                self.destination_address = GroupAddress.parse(@cemi.destination_address.to_i)
            end
        end
    end
end
