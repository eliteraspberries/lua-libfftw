-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local fftwf = {}

local ffi = require('ffi')

local libfftw3f = ffi.load('fftw3f')

fftwf.FFTW_BACKWARD = 1
fftwf.FFTW_ESTIMATE = 64
fftwf.FFTW_FORWARD = -1
fftwf.FFTW_MEASURE = 0

ffi.cdef([[
    struct fftwf_plan_s {
        void *pln;
        void *prb;
        int sign;
    };
    typedef struct fftwf_plan_s *fftwf_plan;
    fftwf_plan fftwf_plan_dft_r2c_1d(int, float *, void *, unsigned);
    fftwf_plan fftwf_plan_dft_c2r_1d(int, void *, float *, unsigned);
    void fftwf_destroy_plan(fftwf_plan);
    void fftwf_execute(const fftwf_plan);
    void fftwf_execute_dft_r2c(const fftwf_plan, float *, void *);
    void fftwf_execute_dft_c2r(const fftwf_plan, void *, float *);
]])

fftwf.plans = {}
fftwf.threads = false

function fftwf.plan_dft(n, x, X)
    if fftwf.plans[n] == nil then
        local flags = fftwf.FFTW_ESTIMATE
        fftwf.plans[n] = {
            libfftw3f.fftwf_plan_dft_r2c_1d(n, x, X, flags),
            libfftw3f.fftwf_plan_dft_c2r_1d(n, X, x, flags),
        }
    end
    return fftwf.plans[n]
end

local function mid(n)
    return math.ceil((n - 1) / 2) + 1
end

function fftwf.rfft(x, n, X)
    local plans = fftwf.plan_dft(n, x, X)
    libfftw3f.fftwf_execute_dft_r2c(plans[1], x, X)
    if n > 2 then
        ffi.fill(X + mid(n), ffi.sizeof(ffi.typeof(X), n - mid(n)), 0)
    end
end

function fftwf.irfft(X, n, x)
    local plans = fftwf.plan_dft(n, x, X)
    libfftw3f.fftwf_execute_dft_c2r(plans[2], X, x)
    local d = 1 / n
    for i = 0, n - 1 do
        x[i] = x[i] * d
    end
end

local suffixes = {'_omp', '_threads'}
for _, suffix in pairs(suffixes) do
    local ok, result = pcall(ffi.load, 'fftw3f' .. suffix)
    if ok then
        local lib = result
        fftwf.threads = true
        fftwf.init_threads = function ()
            lib.fftwf_init_threads()
        end
        fftwf.plan_with_nthreads = function (n)
            lib.fftwf_plan_with_nthreads(n)
        end
        break
    end
end

return fftwf
