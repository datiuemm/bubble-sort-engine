import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import random


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 10)
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
    actual = []
    timeout = 0

    prev_handshake = 0

    while len(actual) < count and timeout < 1000:
        ready = random.choice([0, 1, 1])

        cur = int(dut.uio_in.value)
        cur = (cur & ~(1 << 3)) | (ready << 3)
        dut.uio_in.value = cur

        await RisingEdge(dut.clk)

        uio_val = int(dut.uio_out.value)
        data = int(dut.uo_out.value)

        valid = (uio_val & 0x20) != 0
        handshake = valid and ready

        if handshake and not prev_handshake:
            actual.append(data)

        prev_handshake = handshake
        timeout += 1

    return actual

@cocotb.test()
async def test_bubble_sort_comprehensive(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    test_cases = [
        [8, 7, 6, 5, 4, 3, 2, 1],
        [1, 2, 3, 4, 5, 6, 7, 8],
        [5, 5, 2, 8, 2, 1, 9, 0],
        [42],
        [10, 20, 15]
    ]

    for case in test_cases:
        await reset_dut(dut)
        await send_data(dut, case)

        while True:
            await RisingEdge(dut.clk)
            if int(dut.uio_out.value) & 0x20:
                break

        result = await collect_data(dut, len(case))
        assert result == sorted(case), f"FAIL: input={case}, output={result}"

    for _ in range(3):
        size = random.randint(2, 8)
        rand_case = [random.randint(0, 255) for _ in range(size)]

        await reset_dut(dut)
        await send_data(dut, rand_case)

        while True:
            await RisingEdge(dut.clk)
            if int(dut.uio_out.value) & 0x20:
                break

        result = await collect_data(dut, size)
        assert result == sorted(rand_case), f"FAIL: input={rand_case}, output={result}"
