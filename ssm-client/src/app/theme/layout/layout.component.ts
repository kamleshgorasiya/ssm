import { Component, OnInit, AfterViewInit } from '@angular/core';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-layout',
  templateUrl: './layout.component.html',
  styleUrls: ['./layout.component.css']
})
export class LayoutComponent implements OnInit {
  footer=false;
  categoryId;
  constructor(private _dataExchangeService:DataExchangeService) {
    
   }

  ngOnInit() {
    this._dataExchangeService.footerRest.subscribe(
      ()=>{this.footer=true; console.log("true") }
    )
    setTimeout(() => {
      this.footer=true;
      
    }, 2000);
  }

}
