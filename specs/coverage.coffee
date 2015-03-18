require('coffee-coverage').register({
    path: 'relative',
    # These options do not work as expected
    # basePath: 'src',
    # exclude: ['specs/unit'],
    initAll: true,
})
