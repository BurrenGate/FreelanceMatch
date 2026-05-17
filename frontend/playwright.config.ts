import { createLovableConfig } from "lovable-agent-playwright-config/config";

export default createLovableConfig({
  // Увеличиваем таймаут до 60 секунд, чтобы тесты не падали, 
  // если бэкенд или фронтенд будут "думать" чуть дольше обычного
  timeout: 60000,
  
  use: {
    // Указываем базовый URL твоего ЗАПУЩЕННОГО фронтенда. 
    // По умолчанию Vite использует 5173. Если твой npm run dev выдал другой порт, 
    // просто поменяй цифры здесь!
    baseURL: 'http://localhost:5173',
    
    // Полезные настройки: если тест упадет, Playwright сделает скриншот,
    // чтобы ты мог посмотреть, что пошло не так
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
});