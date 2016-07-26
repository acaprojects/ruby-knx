# encoding: ASCII-8BIT
# frozen_string_literal: true

class KNX
    class ObjectServer
        Errors = {
            0 => :no_error,
            1 => :device_internal_error,
            2 => :no_item_found,
            3 => :buffer_is_too_small,
            4 => :item_not_writeable,
            5 => :service_not_supported,
            6 => :bad_service_param,
            7 => :wrong_datapoint_id,
            8 => :bad_datapoint_command,
            9 => :bad_datapoint_length,
            10 => :message_inconsistent,
            11 => :object_server_busy
        }

        Datagram = Struct.new(:knx_header, :connection, :header) do
            def initialize(raw_data = nil)
                super(Header.new, ConnectionHeader.new, ObjectHeader.new)
                # These values are unique to the KNX Object Server
                self.knx_header.version = 0x20
                self.knx_header.request_type = 0xF080
                @data = []

                if raw_data
                    self.knx_header.read(raw_data[0..5])
                    self.connection.read(raw_data[6..9])
                    self.header.read(raw_data[10..15])

                    # Check for error
                    if self.header.item_count == 0
                        @error_code = raw_data[16].getbyte(0)
                        @error = Errors[@error_code]
                    else
                        @error_code = 0
                        @error = :no_error

                        # Read the response
                        index = 16
                        self.header.item_count.times do
                            next_index = index + 4
                            item = StatusItem.new
                            item.read(raw_data[index...next_index])

                            index = next_index + item.value_length
                            item.value = raw_data[next_index...index]

                            @data << item
                        end
                    end
                end
            end


            attr_reader :error, :error_code, :data


            def error?
                @error_code != 0
            end

            def to_binary_s
                self.header.item_count = @data.length if @data.length > 0
                resp = String.new "#{self.connection.to_binary_s}#{self.header.to_binary_s}"

                @data.each do |item|
                    resp << item.to_binary_s
                end

                self.knx_header.request_length = resp.length + 6
                resp.prepend self.knx_header.to_binary_s
                resp
            end

            def add_action(index, data: nil, **options)
                req = RequestItem.new
                req.id = index.to_i
                req.command = Commands[options[:command]] || :set_value
                if not data.nil?
                    if data == true || data == false
                        data = data ? 1 : 0
                    end

                    if data.is_a? String
                        req.value = data
                    else
                        req.value = String.new
                        req.value << data
                    end
                end
                @data << req
                self
            end
        end
    end
end
