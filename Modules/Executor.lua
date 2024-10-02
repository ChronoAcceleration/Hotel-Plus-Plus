-- Executor.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local Module = {}

function Module:ReturnExecutor(): string
    return identifyexecutor() or "Unknown"
end

function Module:IsSolara(): boolean
    local ExecutorIdentity = self:ReturnExecutor()
    return ExecutorIdentity == "Solara 3.0"
end

return Module