module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
        'scope-empty': [2, 'never'], // require scope, e.g. feat(scorecard): ...
        'body-max-line-length': [0]
    }
};