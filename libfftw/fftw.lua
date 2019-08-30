-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local fftw = {}

local ffi = require('ffi')

local libfftw3 = ffi.load('fftw3')

fftw.FFTW_BACKWARD = 1
fftw.FFTW_ESTIMATE = 64
fftw.FFTW_FORWARD = -1
fftw.FFTW_MEASURE = 0

ffi.cdef([[
    struct fftw_plan_s {
        void *pln;
        void *prb;
        int sign;
    };
    typedef struct fftw_plan_s *fftw_plan;
    fftw_plan fftw_plan_dft_r2c_1d(int, float *, void *, unsigned);
    fftw_plan fftw_plan_dft_c2r_1d(int, void *, float *, unsigned);
    void fftw_destroy_plan(fftw_plan);
    void fftw_execute(const fftw_plan);
    void fftw_execute_dft_r2c(const fftw_plan, float *, void *);
    void fftw_execute_dft_c2r(const fftw_plan, void *, float *);
    int fftw_init_threads(void);
    void fftw_plan_with_nthreads(int);
    void fftw_cleanup_threads(void);
]])

fftw.plans = {}
fftw.threads = false

function fftw.plan_dft(n, x, X)
    if fftw.plans[n] == nil then
        local flags = fftw.FFTW_ESTIMATE
        fftw.plans[n] = {
            libfftw3.fftw_plan_dft_r2c_1d(n, x, X, flags),
            libfftw3.fftw_plan_dft_c2r_1d(n, X, x, flags),
        }
    end
    return fftw.plans[n]
end

local function mid(n)
    return math.ceil((n - 1) / 2) + 1
end

function fftw.rfft(x, n, X)
    local plans = fftw.plan_dft(n, x, X)
    libfftw3.fftw_execute_dft_r2c(plans[1], x, X)
    if n > 2 then
        ffi.fill(X + mid(n), ffi.sizeof(ffi.typeof(X), n - mid(n)), 0)
    end
end

function fftw.irfft(X, n, x)
    local plans = fftw.plan_dft(n, x, X)
    libfftw3.fftw_execute_dft_c2r(plans[2], X, x)
    local d = 1 / n
    for i = 0, n - 1 do
        x[i] = x[i] * d
    end
end

local suffixes = {'_omp', '_threads'}
for _, suffix in pairs(suffixes) do
    local ok, result = pcall(ffi.load, 'fftw3' .. suffix)
    if ok then
        local lib = result
        fftw.threads = true
        fftw.init_threads = function ()
            lib.fftw_init_threads()
        end
        fftw.plan_with_nthreads = function (n)
            lib.fftw_plan_with_nthreads(n)
        end
        break
    end
end

return fftw
