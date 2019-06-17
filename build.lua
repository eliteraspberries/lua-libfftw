local function sub(subs, x)
    local out = x
    for pattern, replace in pairs(subs) do
        out = string.gsub(out, pattern, replace)
    end
    return out
end
local prefixes = {double = '', float = 'f'}
for type, prefix in pairs(prefixes) do
    local name = 'fftw' .. prefix
    local libname = string.gsub(name, 'fftw', 'fftw3')
    local subs = {
        ['{{name}}'] = name,
        ['{{libname}}'] = libname,
        ['{{type}}'] = type,
    }
    local mod = io.open('libfftw/' .. name .. '.lua', 'w')
    io.output(mod)
    for line in io.lines('libfftw/fftw.lua.in') do
        io.write(sub(subs, line), '\n')
    end
    io.close(mod)
    local test = io.open('test-' .. name .. '.lua', 'w')
    io.output(test)
    for line in io.lines('test-fftw.lua.in') do
        io.write(sub(subs, line), '\n')
    end
    io.close(test)
end
