return {
  code = 'signup',
  { id = 'background',
    kind = 'Element',
    properties = {
      width = .999999,
      height = .999999,
      background = {0, 0, 0}
    }
  },
  { id = 'username',
    kind = 'TextField',
    properties = {
      x = .2,
      y = .5,
      width = .4,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = '',
      placeholder = 'Username',
      border = {255, 255, 255}
    }
  },
  { id = 'password',
    kind = 'Password',
    properties = {
      x = .2,
      y = .58,
      width = .4,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = '',
      placeholder = 'Password',
      border = {255, 255, 255}
    }
  },
  { id = 'passwordRetype',
    kind = 'Password',
    properties = {
      x = .2,
      y = .66,
      width = .4,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = '',
      placeholder = 'Retype Password',
      border = {255, 255, 255}
    }
  },
  { id = 'signupButton',
    kind = 'Button',
    properties = {
      x = .2,
      y = .74,
      width = .1,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = 'Sign up',
      center = true,
      border = {255, 255, 255}
    }
  },
  { id = 'cancelButton',
    kind = 'Button',
    properties = {
      x = .32,
      y = .74,
      width = .1,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = 'Cancel',
      center = true,
      border = {255, 255, 255}
    } 
  },
  { id = 'exitButton',
    kind = 'Button',
    properties = {
      x = .82,
      y = .90,
      width = .1,
      height = .05,
      padding = 8,
      font = 'aeromatics',
      text = 'Quit',
      center = true,
      border = {255, 255, 255}
    }
  }
}
