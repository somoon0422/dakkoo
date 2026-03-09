abstract class ExportRepository {
  Future<String> exportAsZip({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<String> exportAsPdf({
    DateTime? startDate,
    DateTime? endDate,
  });
}
