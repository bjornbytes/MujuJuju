return {
  { id = 'background',
    kind = 'Element',
    properties = {
      width = .999999,
      height = .999999,
      background = {0, 0, 0, 0}
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
      font = 'mesmerize',
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
      font = 'mesmerize',
      text = '',
      placeholder = 'Password',
      border = {255, 255, 255}
    }
  },
  { id = 'loginButton',
    kind = 'Button',
    properties = {
      x = .2,
      y = .66,
      width = .1,
      height = .05,
      padding = 8,
      font = 'mesmerize',
      text = 'Login',
      center = true,
      border = {255, 255, 255}
    }
  },
  { id = 'signupButton',
    kind = 'Button',
    properties = {
      x = .5,
      y = .66,
      width = .1,
      height = .05,
      padding = 8,
      font = 'mesmerize',
      text = 'Sign up',
      center = true
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
      font = 'mesmerize',
      text = 'Quit',
      center = true,
      border = {255, 255, 255}
    }
  }
}
