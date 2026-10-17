import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/features/documents/data/document_models.dart';
import 'package:golden_hour/features/documents/data/document_repository.dart';
import 'package:golden_hour/features/documents/domain/document_provider.dart';
import 'package:golden_hour/features/documents/domain/document_state.dart';
import 'package:golden_hour/features/documents/presentation/document_viewer_screen.dart';
import 'package:golden_hour/features/documents/presentation/documents_screen.dart';

class MockDocumentNotifier extends DocumentNotifier {
  MockDocumentNotifier(DocumentState initialState)
      : super(_FakeDocumentRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadDocuments() async {}
}

class _FakeDocumentRepository implements DocumentRepository {
  @override
  Future<List<DocumentItem>> getDocuments() async => [];

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Module 5 — Document Models & Formatting', () {
    test('DocumentItem deserializes and computes properties correctly', () {
      final json = {
        'id': 'doc-1',
        'file_name': 'Blood_Test_Report.pdf',
        'file_type': 'lab_report',
        'mime_type': 'application/pdf',
        'file_size_bytes': 1572864, // 1.5 MB
        'public_url': 'https://storage.supabase.co/docs/report.pdf',
        'uploaded_at': '2026-10-17T12:00:00Z',
      };

      final doc = DocumentItem.fromJson(json);
      expect(doc.id, 'doc-1');
      expect(doc.fileName, 'Blood_Test_Report.pdf');
      expect(doc.typeEnum, DocumentType.labReport);
      expect(doc.isPdf, true);
      expect(doc.isImage, false);
      expect(doc.formattedSize, '1.5 MB');

      final serialized = doc.toJson();
      expect(serialized['file_type'], 'lab_report');
    });

    test('DocumentItem image and small size formatting', () {
      final doc = DocumentItem(
        id: 'doc-2',
        fileName: 'Prescription.jpg',
        fileType: 'prescription',
        mimeType: 'image/jpeg',
        fileSizeBytes: 204800, // 200 KB
        uploadedAt: DateTime.now(),
      );

      expect(doc.isImage, true);
      expect(doc.isPdf, false);
      expect(doc.formattedSize, '200.0 KB');
      expect(doc.typeEnum, DocumentType.prescription);
    });

    test('DocumentState filters items by selected category', () {
      final d1 = DocumentItem(
        id: '1',
        fileName: 'Rx.png',
        fileType: 'prescription',
        mimeType: 'image/png',
        fileSizeBytes: 100,
        uploadedAt: DateTime.now(),
      );
      final d2 = DocumentItem(
        id: '2',
        fileName: 'Lab.pdf',
        fileType: 'lab_report',
        mimeType: 'application/pdf',
        fileSizeBytes: 100,
        uploadedAt: DateTime.now(),
      );

      final stateAll = DocumentState(documents: [d1, d2], selectedFilter: 'all');
      expect(stateAll.filteredDocuments.length, 2);

      final stateRx = DocumentState(
        documents: [d1, d2],
        selectedFilter: 'prescription',
      );
      expect(stateRx.filteredDocuments.length, 1);
      expect(stateRx.filteredDocuments.first.fileName, 'Rx.png');
    });
  });

  group('Module 5 — Documents Presentation Screens', () {
    testWidgets('DocumentsScreen renders header, filter chips, and empty state',
        (tester) async {
      const mockState = DocumentState(
        documents: [],
        isLoading: false,
      );

      final router = GoRouter(
        initialLocation: '/documents',
        routes: [
          GoRoute(
            path: '/documents',
            builder: (_, __) => const DocumentsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentNotifierProvider
                .overrideWith((ref) => MockDocumentNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Medical Documents'), findsOneWidget);
      expect(find.textContaining('Encrypted & Confidential'), findsOneWidget);
      expect(find.text('All Documents'), findsOneWidget);
      expect(find.text('Prescription'), findsOneWidget);
      expect(find.text('Lab Report'), findsOneWidget);
      expect(find.text('Discharge Summary'), findsOneWidget);
      expect(find.text('Insurance Card'), findsOneWidget);
      expect(find.text('No Documents Found'), findsOneWidget);
      expect(find.text('Upload Document'), findsOneWidget);
    });

    testWidgets('DocumentsScreen renders document item card', (tester) async {
      final doc = DocumentItem(
        id: 'doc-10',
        fileName: 'Cardiology_Discharge.pdf',
        fileType: 'discharge_summary',
        mimeType: 'application/pdf',
        fileSizeBytes: 524288, // 512 KB
        publicUrl: 'https://storage.supabase.co/discharge.pdf',
        uploadedAt: DateTime(2026, 10, 15),
      );

      final mockState = DocumentState(
        documents: [doc],
        isLoading: false,
      );

      final router = GoRouter(
        initialLocation: '/documents',
        routes: [
          GoRoute(
            path: '/documents',
            builder: (_, __) => const DocumentsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentNotifierProvider
                .overrideWith((ref) => MockDocumentNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Cardiology_Discharge.pdf'), findsOneWidget);
      expect(find.text('Discharge Summary'), findsWidgets);
      expect(find.textContaining('512.0 KB'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('DocumentViewerScreen renders document title and actions',
        (tester) async {
      final doc = DocumentItem(
        id: 'doc-view',
        fileName: 'Lab_Report_2026.pdf',
        fileType: 'lab_report',
        mimeType: 'application/pdf',
        fileSizeBytes: 1000,
        publicUrl: 'https://storage.supabase.co/lab.pdf',
        uploadedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DocumentViewerScreen(document: doc),
        ),
      );

      expect(find.text('Lab_Report_2026.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.open_in_browser_rounded), findsOneWidget);
    });
  });
}
