local _, SAP = ... -- Internal namespace

local WeakAura_Links = {
    ["Manaforge"] = "https://wago.io/NSManaforge"
}

function SAP:GetWeakAuraLink(name)
    return WeakAura_Links[name] or ""
end