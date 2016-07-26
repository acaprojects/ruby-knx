#encoding: ASCII-8BIT

class KNX
    class ObjectServer
        Commands = {
            0 => :no_command,
            1 => :set_value,
            2 => :send_value,
            3 => :set_value_and_send,
            4 => :read_value,
            5 => :clear_transmission_state
        }
        Commands.merge!(Commands.invert)

        class RequestItem < BinData::Record
            endian :big

            uint16 :id
            bit4   :reserved
            bit4   :command
            uint8  :value_length


            attr_accessor :value


            def to_binary_s
                self.value_length = @value ? @value.length : 0
                "#{super()}#{@value}"
            end
        end
    end
end
