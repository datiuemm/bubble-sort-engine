import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
import random


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


async def send_data(dut, data):
    dut.uio_in.value = 1
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0

    while True:
        await RisingEdge(dut.clk)
        if int(dut.uio_out.value) & 0x10:
            break

    for i, val in enumerate(data):
        dut.ui_in.value = val

        ctrl = (1 << 1)
        if i == len(data) - 1:
            ctrl |= (1 << 2)

        dut.uio_in.value = ctrl
        await RisingEdge(dut.clk)

    dut.uio_in.value = 0


async def collect_data(dut, count):
    result = []
    timeout = 0

    while len(result) < count and timeout < 1000:
        dut.uio_in.value |= (1 << 3)

        await RisingEdge(dut.clk)

        uio = int(dut.uio_out.value)
        valid = (uio & 0x20) != 0

        if valid:
            result.append(int(dut.uo_out.value))

        timeout += 1

    return result


@cocotb.test()
async def test_bubble_sort(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    testcases = [
        [8,7,6,5,4,3,2,1],
        [1,2,3,4],
        [5,1,5,2],
        [42],
        [10,20,15]
    ]

    for case in testcases:
        await reset_dut(dut)
        await send_data(dut, case)

        while True:
            await RisingEdge(dut.clk)
            if int(dut.uio_out.value) & 0x20:
                break

        out = await collect_data(dut, len(case))

        assert out == sorted(case), f"{case} -> {out}"
