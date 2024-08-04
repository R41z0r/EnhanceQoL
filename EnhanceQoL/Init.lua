local addonName, addon = ...
_G[addonName] = addon
addon.saveVariables = {} --Cross-Module variables for DB Save

addon.variables = {}
addon.variables.numOfTabs = 0
addon.L = {} --Language