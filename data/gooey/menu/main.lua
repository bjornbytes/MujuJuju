return {
	code = 'main',
	{ id = 'background',
		kind = 'Element',
		properties = {
			width = .999999,
			height = .999999,
			background = {0, 0, 0}
		}
  },
  { id = 'header',
    kind = 'Element',
    properties = {
      width = .999999,
      height = 48,
      background = {255, 255, 255, 50}
    }
  },
  { id = 'editButton',
    kind = 'Button',
    properties = {
      x = 4,
      y = 4,
      width = 40,
      height = 40,
      border = {255, 255, 255},
      font = 'aeromatics'
    }
  },
  { id = 'optionsButton',
    kind = 'Button',
    properties = {
      x = 40 + 8,
      y = 4,
      width = 40,
      height = 40,
      anchor = 'right',
      border = {255, 255, 255},
      font = 'aeromatics'
    }
  },
  { id = 'exitButton',
    kind = 'Button',
    properties = {
      x = 4,
      y = 4,
      width = 40,
      height = 40,
      anchor = 'right',
      border = {255, 255, 255},
      font = 'aeromatics'
    }
  },
  { id = 'survivalButton',
    kind = 'Button',
    properties = {
      x = .2,
      y = .8,
      width = .25,
      height = .1,
      padding = .01,
      border = {255, 255, 255},
      font = 'inglobalb',
      text = 'Survival',
      center = true
    }
  },
  { id = 'versusButton',
    kind = 'Button',
    properties = {
      x = .55,
      y = .8,
      width = .25,
      height = .1,
      padding = .01,
      border = {255, 255, 255},
      font = 'inglobalb',
      text = 'Versus',
      center = true
    }
  }
}
