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
  mobileError="";
  selectError="";

  constructor(private _addressService:AddressService,
              private _dataExchangeSevice:DataExchangeService,
              private _router:Router) { }

  ngOnInit() {
    // getting address of user if user entered address in past.

    this._addressService.getAddress()
    .subscribe(
      res=>{
          this.address.address1=res[0].address_1;
          this.address.address2=res[0].address_2;
          this.address.city=res[0].city;
          this.address.country=res[0].country;
          this.address.postalCode=res[0].postal_code;
          this.region_id=res[0].shipping_region_id;
      }
    )
          
    // getting shipping regions for address    
    
    this._addressService.getShippingRegion()
    .subscribe(
      res=>{
        this.shippingRegions=res;
        this.country=this.shippingRegions[0].shipping_region;
        this.region_id=this.shippingRegions[0].shipping_region_id;
      }
    );
    
  }

  // Save the address to database.
  
  saveAddress(){
    if(this.country=="Please Select"){
      this.selectError="Select the country";
    } else {
     
      if(this.region_id==1){
        this.selectError="Select the region";
      } else {
        
          this.selectError="";
          this.address.country=this.country;
          this.address.shipping_region_id=this.region_id;
          this.address.shipping_id=this.shippingOption;
          if(this.address.address2==null){
            this.address.address2=" ";
          }

          // If user has already address,it will redirect to display address page 
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
