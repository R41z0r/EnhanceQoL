local addonName, addon = ...
_G[addonName] = addon
addon.saveVariables = {} --Cross-Module variables for DB Save

addon.L = {} --Language