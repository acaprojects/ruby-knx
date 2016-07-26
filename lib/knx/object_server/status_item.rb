# encoding: ASCII-8BIT
# frozen_string_literal: true

class KNX
    class ObjectServer
        Status = {
            0 => :idle_ok,
            1 => :idle_error,
            2 => :transmission_in_progress,
            3 => :transmission_request
        }

        class StatusItem < BinData::Record
            endian :big

            uint16 :id

            bit3   :reserved
            bit1   :valid
            bit1   :update_from_bus
            bit1   :data_request
            bit2   :status

            uint8  :value_length


            attr_accessor :value


            def to_binary_s
                self.value_length = @value ? @value.length : 0
                "#{super()}#{@value}"
            end

            def transmission_status
                ::KNX::ObjectServer::Status[self.status]
            end
        end
    end
end
