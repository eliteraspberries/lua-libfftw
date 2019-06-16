local ffi = require('ffi')
local libfftw = require('libfftw')
local fft = libfftw.fftwf

local tests = {
    {
        {1.0},
        {1.0, 0.0},
    },
    {
        {1.0, 2.0},
        {{3.0, 0.0}, {-1.0, 0.0}},
    },
    {
        {1.0, 2.0, 3.0},
        {{6.0, 0.0}, {-1.5, 0.866025}, {0.0, 0.0}},
    },
    {
        {1.0, 2.0, 3.0, 4.0},
        {{10.0, 0.0}, {-2.0, 2.0}, {-2.0, 0.0}, {0.0, 0.0}},
    },
}

local function eq(x, y)
    return math.abs(x - y) < 1e-6
end

for i, test in pairs(tests) do
    local n = #test[1]
    local x = ffi.new('float[?]', n, test[1])
    local y = ffi.new('float[?]', n)
    local X = ffi.new('complex float[?]', n)
    local Y = ffi.new('complex float[?]', n, test[2])
    fft.rfft(x, n, X)
    for j = 0, n - 1 do
        assert(eq(X[j].re, Y[j].re) and eq(X[j].im, Y[j].im))
    end
    fft.irfft(X, n, y)
    for j = 0, n - 1 do
        assert(eq(x[j], y[j]))
    end
end