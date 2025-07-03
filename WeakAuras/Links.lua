local _, SAP = ... -- Internal namespace

local WeakAura_Links = {
    ["Manaforge"] = "https://wago.io/SAP_Manaforge"
}

function SAP:GetWeakAuraLink(name)
    return WeakAura_Links[name] or ""
end