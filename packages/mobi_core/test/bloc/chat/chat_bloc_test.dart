import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:fake_async/fake_async.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late ChatBloc chatBloc;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    chatBloc = ChatBloc(chatRepository: mockChatRepository);

    // Register fallback values for mocktail
    registerFallbackValue(FakeChatMessage());
  });

  tearDown(() {
    chatBloc.close();
  });

  group('ChatBloc', () {
    group('LoadChatMessages', () {
      final messages = [
        TestData.testChatMessage(id: 1, message: 'Hello!', senderId: 1),
        TestData.testChatMessage(id: 2, message: 'Hi there!', senderId: 2),
        TestData.testChatMessage(id: 3, message: 'How are you?', senderId: 1),
      ];

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatMessagesLoaded] when loading succeeds',
        build: () {
          when(() => mockChatRepository.getChatMessages(any()))
              .thenAnswer((_) async => TestData.successResponse(
                    data: messages.map((m) => m.toJson()).toList(),
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatMessages(rideId: 1)),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatMessagesLoaded>()
              .having((s) => s.messages.length, 'messages count', 3)
              .having((s) => s.messages.first.message, 'first message', 'Hello!')
              .having((s) => s.messages.last.message, 'last message', 'How are you?'),
        ],
        verify: (_) {
          verify(() => mockChatRepository.getChatMessages(1)).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatMessagesLoaded] with empty list when no messages',
        build: () {
          when(() => mockChatRepository.getChatMessages(any()))
              .thenAnswer((_) async => TestData.successResponse(data: []));
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatMessages(rideId: 1)),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatMessagesLoaded>()
              .having((s) => s.messages.isEmpty, 'empty messages', true),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatLoading, ChatError] when loading fails',
        build: () {
          when(() => mockChatRepository.getChatMessages(any()))
              .thenThrow(Exception('Failed to load messages'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatMessages(rideId: 1)),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatError>()
              .having((s) => s.message, 'error message', contains('Failed')),
        ],
      );
    });

    group('SendMessage', () {
      final sentMessage = TestData.testChatMessage(
        id: 10,
        rideId: 1,
        message: 'Test message',
        senderId: 1,
        type: 'text',
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatSendingMessage, ChatMessageSent] when sending succeeds',
        build: () {
          when(() => mockChatRepository.sendMessage(
                rideId: any(named: 'rideId'),
                message: any(named: 'message'),
                type: any(named: 'type'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: sentMessage.toJson(),
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendMessage(
          rideId: 1,
          message: 'Test message',
        )),
        expect: () => [
          isA<ChatSendingMessage>()
              .having((s) => s.message, 'sending message', 'Test message'),
          isA<ChatMessageSent>()
              .having((s) => s.message.id, 'message id', 10)
              .having((s) => s.message.message, 'message text', 'Test message')
              .having((s) => s.message.type, 'message type', 'text'),
        ],
        verify: (_) {
          verify(() => mockChatRepository.sendMessage(
                rideId: 1,
                message: 'Test message',
                type: 'text',
              )).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatSendingMessage, ChatMessageSendFailed] when sending fails',
        build: () {
          when(() => mockChatRepository.sendMessage(
                rideId: any(named: 'rideId'),
                message: any(named: 'message'),
                type: any(named: 'type'),
              )).thenThrow(Exception('Network error'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendMessage(
          rideId: 1,
          message: 'Test message',
        )),
        expect: () => [
          isA<ChatSendingMessage>(),
          isA<ChatMessageSendFailed>()
              .having((s) => s.error, 'error', contains('Network error')),
        ],
      );
    });

    group('SendImageMessage', () {
      final imageMessage = TestData.testChatMessage(
        id: 11,
        rideId: 1,
        message: '',
        type: 'image',
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatSendingMessage, ChatMessageSent] when image upload succeeds',
        build: () {
          when(() => mockChatRepository.sendImageMessage(
                rideId: any(named: 'rideId'),
                imagePath: any(named: 'imagePath'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: imageMessage.toJson(),
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendImageMessage(
          rideId: 1,
          imagePath: '/path/to/image.jpg',
        )),
        expect: () => [
          isA<ChatSendingMessage>()
              .having((s) => s.message, 'sending message', 'Enviando imagem...'),
          isA<ChatMessageSent>()
              .having((s) => s.message.type, 'message type', 'image'),
        ],
        verify: (_) {
          verify(() => mockChatRepository.sendImageMessage(
                rideId: 1,
                imagePath: '/path/to/image.jpg',
              )).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatSendingMessage, ChatMessageSendFailed] when image upload fails',
        build: () {
          when(() => mockChatRepository.sendImageMessage(
                rideId: any(named: 'rideId'),
                imagePath: any(named: 'imagePath'),
              )).thenThrow(Exception('Image too large'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendImageMessage(
          rideId: 1,
          imagePath: '/path/to/large-image.jpg',
        )),
        expect: () => [
          isA<ChatSendingMessage>(),
          isA<ChatMessageSendFailed>()
              .having((s) => s.error, 'error', contains('Image too large')),
        ],
      );
    });

    group('SendLocationMessage', () {
      final locationMessage = TestData.testChatMessage(
        id: 12,
        rideId: 1,
        message: 'Localização compartilhada',
        type: 'location',
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatSendingMessage, ChatMessageSent] when location sharing succeeds',
        build: () {
          when(() => mockChatRepository.sendLocationMessage(
                rideId: any(named: 'rideId'),
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: locationMessage.toJson(),
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendLocationMessage(
          rideId: 1,
          latitude: -23.550520,
          longitude: -46.633308,
        )),
        expect: () => [
          isA<ChatSendingMessage>()
              .having((s) => s.message, 'sending message', 'Compartilhando localização...'),
          isA<ChatMessageSent>()
              .having((s) => s.message.type, 'message type', 'location'),
        ],
        verify: (_) {
          verify(() => mockChatRepository.sendLocationMessage(
                rideId: 1,
                latitude: -23.550520,
                longitude: -46.633308,
              )).called(1);
        },
      );
    });

    group('MarkMessagesAsRead', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatMessagesMarkedAsRead] when marking succeeds',
        build: () {
          when(() => mockChatRepository.markMessagesAsRead(any()))
              .thenAnswer((_) async => TestData.successResponse(
                    message: 'Messages marked as read',
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(MarkMessagesAsRead(rideId: 1)),
        expect: () => [
          isA<ChatMessagesMarkedAsRead>()
              .having((s) => s.rideId, 'ride id', 1),
        ],
        verify: (_) {
          verify(() => mockChatRepository.markMessagesAsRead(1)).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatError] when marking fails',
        build: () {
          when(() => mockChatRepository.markMessagesAsRead(any()))
              .thenThrow(Exception('Failed to mark as read'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(MarkMessagesAsRead(rideId: 1)),
        expect: () => [
          isA<ChatError>()
              .having((s) => s.message, 'error message', contains('Failed')),
        ],
      );
    });

    group('NewMessageReceived', () {
      final newMessage = TestData.testChatMessage(
        id: 20,
        message: 'New incoming message',
        senderId: 2,
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatNewMessageReceived] when new message arrives',
        build: () => chatBloc,
        act: (bloc) => bloc.add(NewMessageReceived(message: newMessage)),
        expect: () => [
          isA<ChatNewMessageReceived>()
              .having((s) => s.message.id, 'message id', 20)
              .having((s) => s.message.message, 'message text', 'New incoming message'),
        ],
      );
    });

    group('TypingStatusChanged', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatTypingIndicator] when user starts typing',
        build: () {
          when(() => mockChatRepository.sendTypingStatus(
                rideId: any(named: 'rideId'),
                isTyping: any(named: 'isTyping'),
              )).thenAnswer((_) async => TestData.successResponse());
          return chatBloc;
        },
        act: (bloc) => bloc.add(TypingStatusChanged(
          rideId: 1,
          isTyping: true,
        )),
        expect: () => [
          isA<ChatTypingIndicator>()
              .having((s) => s.rideId, 'ride id', 1)
              .having((s) => s.isTyping, 'is typing', true),
        ],
        verify: (_) {
          verify(() => mockChatRepository.sendTypingStatus(
                rideId: 1,
                isTyping: true,
              )).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatTypingIndicator] when user stops typing',
        build: () {
          when(() => mockChatRepository.sendTypingStatus(
                rideId: any(named: 'rideId'),
                isTyping: any(named: 'isTyping'),
              )).thenAnswer((_) async => TestData.successResponse());
          return chatBloc;
        },
        act: (bloc) => bloc.add(TypingStatusChanged(
          rideId: 1,
          isTyping: false,
        )),
        expect: () => [
          isA<ChatTypingIndicator>()
              .having((s) => s.isTyping, 'is typing', false),
        ],
      );

      test('typing status auto-stops after 3 seconds', () {
        fakeAsync((async) {
          when(() => mockChatRepository.sendTypingStatus(
                rideId: any(named: 'rideId'),
                isTyping: any(named: 'isTyping'),
              )).thenAnswer((_) async => TestData.successResponse());

          final bloc = ChatBloc(chatRepository: mockChatRepository);

          bloc.add(TypingStatusChanged(rideId: 1, isTyping: true));

          // Fast forward 3 seconds
          async.elapse(const Duration(seconds: 3));

          // Verify auto-stop was triggered
          verify(() => mockChatRepository.sendTypingStatus(
                rideId: 1,
                isTyping: true,
              )).called(1);

          bloc.close();
        });
      });
    });

    group('OtherUserTypingReceived', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatTypingIndicator] when other user starts typing',
        build: () => chatBloc,
        act: (bloc) => bloc.add(OtherUserTypingReceived(
          rideId: 1,
          userId: 2,
          isTyping: true,
        )),
        expect: () => [
          isA<ChatTypingIndicator>()
              .having((s) => s.rideId, 'ride id', 1)
              .having((s) => s.isTyping, 'is typing', true)
              .having((s) => s.otherUserId, 'other user id', 2),
        ],
      );
    });

    group('ClearChat', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatInitial] when chat is cleared',
        build: () => chatBloc,
        act: (bloc) => bloc.add(ClearChat()),
        expect: () => [isA<ChatInitial>()],
      );
    });

    group('DeleteMessage', () {
      blocTest<ChatBloc, ChatState>(
        'emits [ChatMessageDeleted] when message deletion succeeds',
        build: () {
          when(() => mockChatRepository.deleteMessage(
                rideId: any(named: 'rideId'),
                messageId: any(named: 'messageId'),
              )).thenAnswer((_) async => TestData.successResponse(
                    message: 'Message deleted',
                  ));
          return chatBloc;
        },
        act: (bloc) => bloc.add(DeleteMessage(
          rideId: 1,
          messageId: 5,
        )),
        expect: () => [
          isA<ChatMessageDeleted>()
              .having((s) => s.rideId, 'ride id', 1)
              .having((s) => s.messageId, 'message id', 5),
        ],
        verify: (_) {
          verify(() => mockChatRepository.deleteMessage(
                rideId: 1,
                messageId: 5,
              )).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'emits [ChatError] when message deletion fails',
        build: () {
          when(() => mockChatRepository.deleteMessage(
                rideId: any(named: 'rideId'),
                messageId: any(named: 'messageId'),
              )).thenThrow(Exception('Cannot delete message'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(DeleteMessage(
          rideId: 1,
          messageId: 5,
        )),
        expect: () => [
          isA<ChatError>()
              .having((s) => s.message, 'error message', contains('Cannot delete')),
        ],
      );
    });

    group('Real-time Message Flow', () {
      final messages = [
        TestData.testChatMessage(id: 1, message: 'First'),
        TestData.testChatMessage(id: 2, message: 'Second'),
      ];
      final newMessage = TestData.testChatMessage(id: 3, message: 'Third');

      blocTest<ChatBloc, ChatState>(
        'handles loading messages then receiving new message',
        build: () {
          when(() => mockChatRepository.getChatMessages(any()))
              .thenAnswer((_) async => TestData.successResponse(
                    data: messages.map((m) => m.toJson()).toList(),
                  ));
          return chatBloc;
        },
        act: (bloc) async {
          bloc.add(LoadChatMessages(rideId: 1));
          await Future.delayed(Duration.zero);
          bloc.add(NewMessageReceived(message: newMessage));
        },
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatMessagesLoaded>()
              .having((s) => s.messages.length, 'loaded messages count', 2),
          isA<ChatNewMessageReceived>()
              .having((s) => s.message.message, 'new message', 'Third'),
        ],
      );
    });

    group('Message Type Detection', () {
      test('text message has correct type', () {
        final message = TestData.testChatMessage(
          message: 'Hello',
          type: 'text',
        );

        expect(message.type, equals('text'));
        expect(message.message, equals('Hello'));
      });

      test('image message has correct type', () {
        final message = TestData.testChatMessage(
          message: '',
          type: 'image',
        );

        expect(message.type, equals('image'));
      });

      test('location message has correct type', () {
        final message = TestData.testChatMessage(
          message: 'Localização',
          type: 'location',
        );

        expect(message.type, equals('location'));
      });
    });

    group('Error Recovery', () {
      blocTest<ChatBloc, ChatState>(
        'can recover from error and load messages again',
        build: () {
          var callCount = 0;
          when(() => mockChatRepository.getChatMessages(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return TestData.successResponse(data: [
              TestData.testChatMessage().toJson(),
            ]);
          });
          return chatBloc;
        },
        act: (bloc) async {
          bloc.add(LoadChatMessages(rideId: 1));
          await Future.delayed(Duration.zero);
          bloc.add(LoadChatMessages(rideId: 1)); // Retry
        },
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatError>(),
          isA<ChatLoading>(),
          isA<ChatMessagesLoaded>()
              .having((s) => s.messages.length, 'messages count', 1),
        ],
      );
    });

    group('Concurrent Operations', () {
      blocTest<ChatBloc, ChatState>(
        'handles sending message while loading messages',
        build: () {
          when(() => mockChatRepository.getChatMessages(any()))
              .thenAnswer((_) async => TestData.successResponse(data: []));
          when(() => mockChatRepository.sendMessage(
                rideId: any(named: 'rideId'),
                message: any(named: 'message'),
                type: any(named: 'type'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: TestData.testChatMessage(message: 'Test').toJson(),
                  ));
          return chatBloc;
        },
        act: (bloc) {
          bloc.add(LoadChatMessages(rideId: 1));
          bloc.add(SendMessage(rideId: 1, message: 'Test'));
        },
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatMessagesLoaded>(),
          isA<ChatSendingMessage>(),
          isA<ChatMessageSent>(),
        ],
      );
    });
  });
}
