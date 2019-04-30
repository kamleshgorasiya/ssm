import { Component, OnInit } from '@angular/core';
import { PaymentService } from 'src/app/core/mock/payment.service';

@Component({
  selector: 'app-order-detail',
  templateUrl: './order-detail.component.html',
  styleUrls: ['./order-detail.component.css']
})
export class OrderDetailComponent implements OnInit {

  orders;
  count;
  constructor(private _orderService:PaymentService) { }

  ngOnInit() {
    this._orderService.getOrders()
    .subscribe(
      res=>{
        this.orders=res;
        this.count=this.orders.count;
      }
    )
  }

}
