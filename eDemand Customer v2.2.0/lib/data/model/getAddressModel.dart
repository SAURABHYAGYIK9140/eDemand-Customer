// ignore_for_file: public_member_api_docs, sort_constructors_first
class GetAddressModel {
  String? id;
  String? type;
  String? address;
  String? cityName;
  String? area;
  String? mobile;
  String? alternateMobile;
  String? pincode;
  String? cityId;
  String? landmark;
  String? state;
  String? country;
  String? lattitude;
  String? longitude;
  String? isDefault;

  GetAddressModel(
      {this.id,
      this.type,
      this.address,
      this.cityName,
      this.area,
      this.mobile,
      this.alternateMobile,
      this.pincode,
      this.cityId,
      this.landmark,
      this.state,
      this.country,
      this.lattitude,
      this.longitude,
      this.isDefault,});

  GetAddressModel.fromJson(final Map<String, dynamic> json) {
    id =( json['id'] ??"0").toString();
    type =( json['type'] ??"").toString();
    address = (json['address'] ??"").toString();
    cityName = (json['city_name'] ??"").toString();
    area = (json['area'] ??"").toString();
    mobile =( json['mobile'] ??"").toString();
    alternateMobile = (json['alternate_mobile'] ??"").toString();
    pincode = (json['pincode'] ??"").toString();
    cityId = (json['city_id'] ??"").toString();
    landmark = (json['landmark'] ??"").toString();
    state = (json['state'] ??"").toString();
    country = (json['country'] ??"").toString();
    lattitude =( json['lattitude'] ??"").toString();
    longitude = (json['longitude'] ??"").toString();
    isDefault = (json['is_default'] ??"").toString();

  }

}
