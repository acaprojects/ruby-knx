# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    class ObjectServer
        class ConnectionHeader < BinData::Record
            endian :big

            uint8  :header_length,  value: 0x04
            uint8  :reserved1,      value: 0x00
            uint8  :reserved2,      value: 0x00
            uint8  :reserved3,      value: 0x00
        end


        Filters = {
            0 => :all_values,
            1 => :valid_values,
            2 => :updated_values
        }
        Filters.merge!(Filters.invert)

        class ObjectHeader < BinData::Record
            endian :big

            uint8  :main_service, value: 0xF0
            uint8  :sub_service
            uint16 :start_item
            uint16 :item_count

            attr_accessor :filter

            def to_binary_s
                resp = super()
                resp << @filter if @filter
                resp
            end
        end
    end
end
