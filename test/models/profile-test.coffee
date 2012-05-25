profile = require '../../models/profile'

module.exports =
  'Test Data': (test)->
    prof = profile 'image', ['jpg', 'png'],
      'thumb':
        filter:
          crop:
            w: 100
            h: 100
    test.ok prof.match 'file.jpg'
    test.ok !prof.match 'file.txt'
    console.log prof
    test.equal prof.format('thumb').length, 1
    test.ok prof.format('thumb').filter.crop.w
    test.done()
