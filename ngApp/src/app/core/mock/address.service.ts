import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class AddressService {

  private shippingRegionUrl="http://localhost:3000/api/shippingRegion";
  private shippingOptionUrl="http://localhost:3000/api/shippingOptions";
  private addAddressUrl="http://localhost:3000/api/addAddress";
  private getAddressUrl="http://localhost:3000/api/getAddress";

  constructor(private _http:HttpClient,private _authService:AuthService) { }

  setHeader():any{
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return options;
  }

  getShippingRegion(){
    return this._http.get<any>(this.shippingRegionUrl);
  }

  getShippingOptions(){
    return this._http.get<any>(this.shippingOptionUrl);
  }
  addAddress(address){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.addAddressUrl,address,options);
  }
  getAddress(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    console.log("sade")
    return this._http.get<any>(this.getAddressUrl,options)
  }


  private checkoutUrl="http://localhost:3000/payment/checkout";

  paymentcheckOut(details){
    //let options=this.setHeader();
    console.log(details)
   // return this._http.post<any>(this.checkoutUrl,details,options);
  }
}
