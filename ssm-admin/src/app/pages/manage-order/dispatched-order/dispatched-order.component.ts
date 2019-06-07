import { Component, OnInit } from '@angular/core';
import { Order } from 'src/app/core/data/order';
import { OrderService } from 'src/app/core/mock/order.service';

@Component({
  selector: 'app-dispatched-order',
  templateUrl: './dispatched-order.component.html',
  styleUrls: ['./dispatched-order.component.css']
})
export class DispatchedOrderComponent implements OnInit {

  orders:Order[]=new Array();
  displayPages=new Array();
  images=new Array();
  currentPage=1;
  lastPage;
  totalPages;
  limit=10; 
  
  constructor(private _orderService:OrderService) { }

  ngOnInit() {
    this._orderService.countDispatchedOrder()
    .subscribe(
      res=>{
        this.totalPages=Math.ceil(res[0].dispatchedOrder/this.limit);
        this.lastPage=this.totalPages;
        if(this.totalPages>0){
          this.getDispatchedOrder(1);
          this.setPagination();
        }
      }
    );
  }

  getDispatchedOrder(pageno){
    this._orderService.getDispatchedOrder((pageno*10)-10)
    .subscribe(
      res=>{
        //@ts-ignore
        this.orders=res;
        if(this.orders.length>0){
          delete this.images;
          this.images=new Array();
          let img;
          for(let i=0;i<this.orders.length;i++){
            img=JSON.parse(this.orders[i].thumbnail);
            this.images.push(img[0]);
            this.orders[i].attributes=JSON.parse(this.orders[i].attributes);
          }
        }
      }
    )
  }

  setPagination(){
    delete this.displayPages;
    this.displayPages=new Array();
    
    let startPage;
    
    if(this.currentPage>5 && this.currentPage<this.lastPage-5){
      startPage=this.currentPage-5;
      for(let i=0;i<this.currentPage+5;i++){
        this.displayPages.push(startPage);
        startPage=startPage+1;
      }
    } else {
      if(this.currentPage<5){
        for(let i=0;i<10;i++){
          this.displayPages.push(i+1);
          if(i+1==this.lastPage){
            break;
          }
        }
      } else {
        for(let i=this.lastPage-10;i<=this.lastPage;i++){
          if(i>0){
            this.displayPages.push(i);
          }
        }
      }
    }
  }

  deliverOrder(order){
    this._orderService.deliverOrder(order.item_id)
    .subscribe(
      res=>{
        //@ts-ignore
        if(res.success==true){
          for(let i=0;i<this.orders.length;i++){
            if(this.orders[i].item_id===order.item_id){
              this.orders=this.orders.splice(i,1);
              this.images=this.images.splice(i,1);
              break;
            }
          }
        } else {
          window.alert("Order is nor confirmed");
        }
      }
    )
  }

}
