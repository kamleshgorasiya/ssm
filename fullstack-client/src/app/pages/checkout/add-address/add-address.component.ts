import { Component, OnInit } from '@angular/core';
import { AddressService } from 'src/app/core/mock/address.service';
import { Address } from 'src/app/core/data/address';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Message } from '@angular/compiler/src/i18n/i18n_ast';
import { Router } from '@angular/router';

@Component({
  selector: 'app-add-address',
  templateUrl: './add-address.component.html',
  styleUrls: ['./add-address.component.css']
})
export class AddAddressComponent implements OnInit {
  region_id;
  country;
  shippingOption=0;
  shippingRegions=new Array();
  shippingOptions=new Array();
  displayOptions=new Array();
  address=new Address();
 // msg="";
  mobileError="";
  selectError="";
  constructor(private _addressService:AddressService,
              private _dataExchangeSevice:DataExchangeService,
              private _router:Router) { }

  ngOnInit() {
    this._dataExchangeSevice.addressMessage$
    .subscribe(
      message=>{
        // this.msg=message;
        // console.log(this.msg);
        console.log(message)
        if(message=="new"){
         
        }
        else{
          if(message=="edit"){
            this._addressService.getAddress()
            .subscribe(
              res=>{
                  this.address.address1=res[0].address_1;
                  this.address.address2=res[0].address_2;
                  this.address.city=res[0].city;
                  this.address.country=res[0].country;
                  this.address.postalCode=res[0].postal_code;
                  this.region_id=res[0].shipping_region_id;
                console.log(this.address)
              }
            )
          }
        }
      }
    )
    
    this._addressService.getShippingRegion()
    .subscribe(
      res=>{
        this.shippingRegions=res;
        this.country=this.shippingRegions[0].shipping_region;
        this.region_id=this.shippingRegions[0].shipping_region_id;
      }
    );
    this._addressService.getShippingOptions()
    .subscribe(
      res=>{
        this.shippingOptions=res;
      }
    )
    this.displayOptions.push({"shipping_id":0,shipping_type:"Please select", shipping_cost:0,shipping_region_id:1})
    // if(this.msg==""){
    //   this._router.navigate(['']);
    // }
  }

  regionChange(){
    this.displayOptions=this.shippingOptions.filter(option=>option.shipping_region_id==this.region_id)
    this.displayOptions.unshift({"shipping_id":0,shipping_type:"Please select", shipping_cost:0,shipping_region_id:1})
    this.shippingOption=0;
  }

  
  saveAddress(){
    if(this.country=="Please Select"){
      this.selectError="Select the country";
    } else {
     
      if(this.region_id==1){
        this.selectError="Select the region";
      } else {
        if(this.shippingOption==0){
          this.selectError="Select the Shipping Option"
        }else{
          this.selectError="";
          this.address.country=this.country;
          this.address.shipping_region_id=this.region_id;
          this.address.shipping_id=this.shippingOption;
          if(this.address.address2==null){
            this.address.address2=" ";
          }

          this._addressService.addAddress(this.address)
          .subscribe(
            res=>{
              this._router.navigate(['address'])
            }
          )
        }
      }
    }
  }
}
