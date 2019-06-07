import { Injectable } from '@angular/core';
import { HttpClient,HttpClientModule } from '@angular/common/http';
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class AddressService {

  /* Urls for all Address related Apis */

  private shippingRegionUrl=this.headerSetter.baseUrl+"/api/shippingRegion";
  private shippingOptionUrl=this.headerSetter.baseUrl+"/api/shippingOptions";
  private addAddressUrl=this.headerSetter.baseUrl+"/api/addAddress";
  private getAddressUrl=this.headerSetter.baseUrl+"/api/getAddress";

  constructor(private _http:HttpClient,private headerSetter:HeaderSetter) { }

  /* call get shipping regions api */

  getShippingRegion(){
    return this._http.get<any>(this.shippingRegionUrl);
  }

  /* call get shipping options api */

  getShippingOptions(){
    return this._http.get<any>(this.shippingOptionUrl);
  }

  /* call api for adding address of user */

  addAddress(address){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.addAddressUrl,address,options);
  }

  /* call get address api */
  
  getAddress(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this.getAddressUrl,options)
  }
}
