local libfftw = {}

for _, name in pairs({'fftw', 'fftwf'}) do
    local ok, mod = pcall(require, name)
    if ok then
        libfftw[name] = mod
    end
end

return libfftw
