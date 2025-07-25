function fieldInputTypes(fieldType) {
  return {
    isBoolean: fieldType === 'boolean',
    isString: fieldType === 'string',
    isInteger: fieldType === 'integer',
    isJson: fieldType === 'json',
    isSelect: fieldType === 'select'
  }
}

export {
  fieldInputTypes
}