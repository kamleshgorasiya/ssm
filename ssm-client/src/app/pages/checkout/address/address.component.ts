import { Component, OnInit } from '@angular/core';
import { AddressService } from 'src/app/core/mock/address.service';
import { Router } from '@angular/router';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Address } from 'src/app/core/data/address';
import { Apiaddress } from 'src/app/core/data/apiaddress';

@Component({
  selector: 'app-address',
  templateUrl: './address.component.html',
  styleUrls: ['./address.component.css']
})

export class AddressComponent implements OnInit {

  address=new Apiaddress();
  constructor(private _addressService:AddressService,
              private _router:Router,
              private _dataExchangeService:DataExchangeService) { }

  ngOnInit() {
    
    // Getting the address from database. If address not found, transfer control over add address.

    this._addressService.getAddress()
    .subscribe(
      res=>{
        if(res[0].shipping_region_id==1){
          this._dataExchangeService.changeAddress("new");
          this._router.navigate(['add-address']);
        } else {
          this.address=res[0];
        }
      }
    )
  }

  // transfer to edit address page.

  editAddress(){
    this._dataExchangeService.changeAddress("edit");
    this._router.navigate(['add-address']);
  }

  // If user continue then transfer to payment tab.

  continueAddress(){
    localStorage.setItem("payment","address");
    this._router.navigate(['payment']);
  }

  // when user clicks on bag, transfer control to cart detail. 

  bagClick(){
    this._router.navigate(['cart'])
  }
}
