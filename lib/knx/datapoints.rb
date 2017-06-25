# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    def self.datapoint(id, value)
        case id.to_s
        when '9.001'
            TwoByteFloatingPoint.new(value)
        else
            raise "unknown datapoint #{id}"
        end
    end

    class Datapoint
        attr_accessor :value

        def initialize(value)
            if value.is_a?(Array)
                from_datapoint(value)
            else
                @value = value
            end
        end
    end

    class TwoByteFloatingPoint < Datapoint
        def from_datapoint(data)
            val = 0
            m = ((data[0] & 0x07) << 8) | (data[1])
            signed = ((data[0] & 0x80) >> 7) == 1

            if signed
                m = m - 1
                m = ~m & 0x07FF
                val = m * -1
            else
                val = m
            end

            power = (data[0] & 0x78) >> 3
            calc = 0.01 * val

            @value = (calc * (2 ** power)).round(2)
        end

        def to_datapoint
            raise "input value is not in a valid range" if value < -273 || value > 670760

            v = (value * 100.0).round
            e = 0
            while v < -2048.0 do
                v = v / 2
                e += 1
            end
            while v > 2047.0 do
                v = v / 2
                e += 1
            end

            mantissa = 0
            signed = if v < 0
                mantissa = v * -1
                mantissa = ~mantissa & 0x07FF
                mantissa = mantissa + 1
                true
            else
                mantissa = v
                false
            end

            datapoint = [0, 0]
            datapoint[0] = 0x80 if signed
            datapoint[0] = datapoint[0] | ((e & 0x0F) << 3)
            datapoint[0] = datapoint[0] | ((mantissa >> 8) & 0x07)
            datapoint[1] = mantissa & 0xFF
            datapoint
        end
    end
end
