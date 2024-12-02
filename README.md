# Плагин для поиска устройств "Рутокен" компании "Актив"

## **Описание**

Плагин дает возможность поиска устройств "Рутокен" компании "Актив"

Пока Android Only

## **Использование**

Для корректной работы с Bluetooth-устройствами необходимо самостоятельно запросить разрешение "BLUETOOTH_CONNECT"

- Инициализия. Необходимо передать список интерфейсов
  ```dart
  RutokenFlutter.initialize({
    required List<RutokenDeviceType> types,
  })
  ```
- Поток устройств
  ```dart
  Stream<List<RutokenDevice>> deviceStream
  ```

## Todo

- [x] Поддержка iOS
