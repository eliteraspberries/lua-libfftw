LibFFTW is a LuaJIT FFI wrapper for the FFTW library.

LibFFTW supports single- and double-precision, one-dimensional,
real input DFTs.


## Requirements

LibFFTW requires [LuaJIT][] and the [FFTW][] library.


## Usage

    local ffi = require('ffi')
    local fft = require('libfftw.fftwf')

    local x = ffi.new('float[3]', {1, 2, 3})
    local X = ffi.new('complex float[?]', 3)
    fft.rfft(x, n, X)
    fft.irfft(X, n, x)


[FFTW]: <http://www.fftw.org/>
[LuaJIT]: <http://luajit.org/>
