import 'package:e_demand/app/generalImports.dart';

abstract class DeleteAddressState {}

class DeleteAddressInitial extends DeleteAddressState {}

class DeleteAddressInProgress extends DeleteAddressState {}

class DeleteAddressSuccess extends DeleteAddressState {
  List<GetAddressModel> data;
  final String id;

  DeleteAddressSuccess({required this.id, required this.data});
}

class DeleteAddressFail extends DeleteAddressState {
  DeleteAddressFail(this.error);

  final dynamic error;
}

class DeleteAddressCubit extends Cubit<DeleteAddressState> {
  DeleteAddressCubit() : super(DeleteAddressInitial());
  final AddressRepository _address = AddressRepository();

  Future deleteAddress(final String id) async {
    try {
      emit(DeleteAddressInProgress());
      final Map<String, dynamic> response = await _address.deleteAddress(id);

      emit(DeleteAddressSuccess(
          id: id,
          data: (response['data'] as List<dynamic>)
              .map((final entry) => GetAddressModel.fromJson(entry))
              .toList()));
    } catch (e) {
      emit(DeleteAddressFail(e.toString()));
    }
  }
}
