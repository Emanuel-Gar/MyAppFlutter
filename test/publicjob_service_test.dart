import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teayudoapp/services/publicjob_service.dart';

void main() {
  setUp(() {
    publicJobs.value = [];
  });

  test('published jobs are observable and can be accepted', () {
    publishPublicJob(
      PublicJobData(
        serviceType: 'Plomería',
        description: 'Reparar una fuga',
        payment: '350',
        latitude: 19.3,
        longitude: -98.2,
        photoBytes: Uint8List(0),
        photoName: 'job.jpg',
      ),
    );

    final publishedJob = publicJobs.value.single;
    expect(publishedJob.id, isNotEmpty);
    expect(publishedJob.isAccepted, isFalse);

    acceptPublicJob(publishedJob.id);

    expect(publicJobs.value.single.isAccepted, isTrue);
  });
}
