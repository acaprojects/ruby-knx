# frozen_string_literal: true, encoding: ASCII-8BIT

require 'knx'


describe "knx datapoint helper" do
    it "should parse encoded floating point numbers" do
        dp = KNX.datapoint('9.001', [0x8A, 0x24])
        expect(dp.class).to be(KNX::TwoByteFloatingPoint)
        expect(dp.value).to eq(-30)
        expect(dp.to_datapoint).to eq([0x8A, 0x24])

        dp = KNX.datapoint('9.001', [0x0C, 0x7E])
        expect(dp.value).to eq(23.0)
        expect(dp.to_datapoint).to eq([0x0C, 0x7E])

        dp = KNX.datapoint('9.001', 19.5)
        expect(dp.value).to eq(19.5)
        expect(dp.to_datapoint).to eq([0x07, 0x9E])

        dp = KNX.datapoint('9.001', [0x02, 0x44])
        expect(dp.value).to eq(5.8)
        expect(dp.to_datapoint).to eq([0x02, 0x44])

        dp = KNX.datapoint('9.001', [0x85, 0x76])
        expect(dp.value).to eq(-6.5)
        expect(dp.to_datapoint).to eq([0x85, 0x76])

        dp = KNX.datapoint('9.001', 36.7)
        expect(dp.value).to eq(36.7)
        expect(dp.to_datapoint).to eq([0x0F, 0x2B])

        dp = KNX.datapoint('9.001', [0x00, 0x00])
        expect(dp.value).to eq(0)
        expect(dp.to_datapoint).to eq([0x00, 0x00])
    end
end
