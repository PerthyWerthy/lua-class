-- localize globals

local assert       = assert;
local type         = type;
local setmetatable = setmetatable;
local getfenv      = getfenv;

-- create error codes

local error_codes = {
    ["INVALID_ARGUMENT"]  = "Expected type %s type for %s got %s",
    ["INVALID_CLASSNAME"] = "%s is not a valid class name"
}

-- create class functions

local classes = {}

local call_function = function(self, ...)
    if (self.constructor) then
        return self.constructor(...)
    end
end

local function class(class_name)
    assert(type(class_name) == "string",
        error_codes["INVALID_ARGUMENT"]:format("string", "class name", type(class_name))
    )

    return function(class_data)
        classes[class_name] = class_data
    end
end

local function new(class_name)
    local class = classes[class_name]
    assert(class, error_codes["INVALID_CLASSNAME"]:format(class_name))

    local object =
        setmetatable(
        {},
        {
            __index = class,
            __call = call_function
        }
    )

    local constructor = object.constructor do
        if (constructor) then
            assert(type(constructor) == "function",
                error_codes["INVALID_ARGUMENT"]:format("function", "constructor", type(constructor))
            )

            object.constructor = function(...)
                getfenv()["self"] = object

                constructor(...)

                return object
            end
        end
    end

    return object
end

return function()
    return class, new
end
