import { Component, OnInit } from '@angular/core';
import { AddressService } from 'src/app/core/mock/address.service';
import { Router } from '@angular/router';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-address',
  templateUrl: './address.component.html',
  styleUrls: ['./address.component.css']
})
export class AddressComponent implements OnInit {

  address={};
  constructor(private _addressService:AddressService,
              private _router:Router,
              private _dataExchangeService:DataExchangeService) { }

  ngOnInit() {
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

  editAddress(){
    this._dataExchangeService.changeAddress("edit");
    this._router.navigate(['add-address']);
  }

  continueAddress(){
    this._router.navigate(['payment']);
  }

  bagClick(){
    this._router.navigate(['cart'])
  }
}
