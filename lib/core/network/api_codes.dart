const Map<String, String> apiCodeMessages = {
  'RESOURCE_NOT_FOUND': 'Ресурс не найден',
  'VALIDATION_ERROR': 'Неверные данные',
  'NOTHING_TO_UPDATE': 'Нет полей для обновления',
  'INCORRECT_USERNAME_PASSWORD': 'Неверное имя пользователя или пароль',
  'INCORRECT_PASSWORD': 'Текущий пароль не совпадает',
  'NEW_PASSWORD_SAME_AS_OLD': 'Новый пароль совпадает с текущим',
  'PASSWORD_UPDATE_FAILED': 'Не удалось обновить пароль',
  'TOKEN_NOT_PASSED': 'Токен не передан',
  'INVALID_TOKEN': 'Неверный токен',
  'TOKEN_SIGNATURE_EXPIRED': 'Время сессии истекло',
  'TOKEN_REVOKED': 'Токен отозван',
  'INVALID_IDEMPOTENCY_KEY': 'Неверный формат ключа идемпотентности',
  'IDEMPOTENCY_CONFLICT': 'Запрос уже обрабатывается',
  'UNIQUE_CONFLICT': 'Конфликт уникальности',
  'COUPLE_NOT_SELF': 'Нельзя создать пару с самим собой',
  'ALBUM_NOT_FOUND': 'Альбом не найден',
  'FILE_NOT_FOUND': 'Файл не найден',
  'FILE_UPLOAD_PENDING': 'Файл ещё загружается',
  'FILE_UPLOAD_FAILED': 'Ошибка загрузки файла',
  'FILE_DELETED': 'Файл был удалён',
  'FILE_PRESIGNED_URL_GENERATION_FAILED': 'Ошибка при генерации ссылки',
  'UNSUPPORTED_FILE_TYPE': 'Неподдерживаемый тип файла',
  'UPLOAD_NOT_COMPLETED': 'Файл не найден в хранилище',
  'RATE_LIMIT_EXCEEDED': 'Слишком много запросов. Попробуйте позже',
  'INTERNAL_SERVER_ERROR': 'Внутренняя ошибка сервера',
};

String translateApiCode(String code, [String? fallback]) {
  return apiCodeMessages[code] ?? fallback ?? 'Произошла неизвестная ошибка';
}
