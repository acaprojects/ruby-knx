# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    # ------------------------
    #    Address Processing
    # ------------------------
    #           +-----------------------------------------------+
    # 16 bits   |              INDIVIDUAL ADDRESS               |
    #           +-----------------------+-----------------------+
    #           | OCTET 0 (high byte)   |  OCTET 1 (low byte)   |
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    bits   | 7| 6| 5| 4| 3| 2| 1| 0| 7| 6| 5| 4| 3| 2| 1| 0|
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #           |  Subnetwork Address   |                       |
    #           +-----------+-----------+     Device Address    |
    #           |(Area Adrs)|(Line Adrs)|                       |
    #           +-----------------------+-----------------------+

    #           +-----------------------------------------------+
    # 16 bits   |             GROUP ADDRESS (3 level)           |
    #           +-----------------------+-----------------------+
    #           | OCTET 0 (high byte)   |  OCTET 1 (low byte)   |
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    bits   | 7| 6| 5| 4| 3| 2| 1| 0| 7| 6| 5| 4| 3| 2| 1| 0|
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #           |  | Main Grp  | Midd G |       Sub Group       |
    #           +--+--------------------+-----------------------+

    #           +-----------------------------------------------+
    # 16 bits   |             GROUP ADDRESS (2 level)           |
    #           +-----------------------+-----------------------+
    #           | OCTET 0 (high byte)   |  OCTET 1 (low byte)   |
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    bits   | 7| 6| 5| 4| 3| 2| 1| 0| 7| 6| 5| 4| 3| 2| 1| 0|
    #           +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #           |  | Main Grp  |            Sub Group           |
    #           +--+--------------------+-----------------------+
    module Address
        module ClassMethods
            def parse(input)
                address = @address_class.new
                klass = input.class

                if klass == Array
                    address.read(input.pack('n'))
                elsif [Integer, Fixnum].include? klass
                    address.read([input].pack('n'))
                elsif klass == String
                    tmp = parse_friendly(input)
                    if tmp.nil?
                        address.read(input)
                    else
                        address = tmp
                    end
                else
                    raise 'address parsing failed'
                end

                address
            end
        end

        def self.included(base)
            base.instance_variable_set(:@address_class, base)
            base.extend(ClassMethods)
        end

        def to_i
            # 16-bit unsigned, network (big-endian)
            to_binary_s.unpack('n')[0]
        end

        def is_group?; true; end
    end

    class GroupAddress < ::BinData::Record
        include Address
        endian :big

        bit1 :_reserved_,   value: 0
        bit4 :main_group
        bit3 :middle_group
        uint8 :sub_group
        

        def to_s
            "#{main_group}/#{middle_group}/#{sub_group}"
        end

        def self.parse_friendly(str)
            result = str.split('/')
            if result.length == 3
                address = GroupAddress.new
                address.main_group   = result[0].to_i
                address.middle_group = result[1].to_i
                address.sub_group    = result[2].to_i
                address
            end
        end
    end

    class GroupAddress2Level < ::BinData::Record
        include Address
        endian :big

        bit1  :_reserved_,   value: 0
        bit4  :main_group
        bit11 :sub_group
        

        def to_s
            "#{main_group}/#{sub_group}"
        end

        def self.parse_friendly(str)
            result = str.split('/')
            if result.length == 2
                address = GroupAddress2Level.new
                address.main_group = result[0].to_i
                address.sub_group = result[1].to_i
                address
            end
        end
    end

    class IndividualAddress < ::BinData::Record
        include Address
        endian :big

        bit4 :area_address
        bit4 :line_address
        uint8 :device_address
        
        def to_s
            "#{area_address}.#{line_address}.#{device_address}"
        end

        def is_group?; false; end

        def self.parse_friendly(str)
            result = str.split('.')
            if result.length == 3
                address = IndividualAddress.new
                address.area_address = result[0].to_i
                address.line_address = result[1].to_i
                address.device_address = result[2].to_i
            end
        end
    end
end
