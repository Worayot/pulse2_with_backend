import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/utils/mews_form/model/mews_form_state.dart';
import 'package:tuh_mews/utils/mews_form/state/mews_form_controller.dart';

final mewsFormProvider = NotifierProvider.autoDispose<MewsFormController, MewsFormState>(MewsFormController.new);
