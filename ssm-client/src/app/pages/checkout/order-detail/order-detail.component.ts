import { Component, OnInit, ɵConsole } from '@angular/core';
import { PaymentService } from 'src/app/core/mock/payment.service';
import { Product } from 'src/app/core/data/product';
import { OrderProduct } from 'src/app/core/data/order-product';
import { OrderService } from 'src/app/core/mock/order.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-order-detail',
  templateUrl: './order-detail.component.html',
  styleUrls: ['./order-detail.component.css']
})
export class OrderDetailComponent implements OnInit {

  orders=new Array();
  orderDetail=new Array();
  products=new Array();
  commonProduct=new Array();
  allProduct=new Array();
  status=new Array();
  order=new OrderProduct();
  count;
  images;
  product;
  login=0;

  constructor(private _orderService:OrderService,
              private _authService:AuthService,
              private _router:Router) { }

  ngOnInit() {

    if(!this._authService.loggedIn()){
      this.login=1;
    } else {
    // Getting order from database of specific user

    this._orderService.getOrders()
    .subscribe(
      res=>{
        this.orders=res[0];
        this.count=this.orders.length;
        this.orderDetail=res[1];
        this.products=res[2];
        this.commonProduct=res[3];
        for(let i=0;i<this.orders.length;i++){
          for(let j=0;j<this.orderDetail.length;j++){

            if(this.orders[i].order_id==this.orderDetail[j].order_id){
              
              delete this.order;
              this.order=new OrderProduct();
              this.product=this.products.find(item=>item.variant_id==this.orderDetail[j].product_variant_id);
              let p=this.commonProduct.find(item=>item.product_id==this.product.product_id);
              this.order.orderId=this.orderDetail[j].order_id;
              this.order.product_id=this.product.variant_id;
              this.order.name=this.product.name;
              this.order.description=p.description;
              this.order.attributes=JSON.parse(this.orderDetail[j].attributes);
              this.order.placedDate=this.orders[i].created_on;
              this.order.deliveryDate=this.orders[i].shipped_on;
              this.order.price=this.orderDetail[j].quantity*this.product.price;
              this.order.discounted_price=(this.orderDetail[j].quantity*this.product.discounted_price)+this.order.price;
              this.order.quantity=this.orderDetail[j].quantity;
              this.images=JSON.parse(this.product.list_image);
              this.order.image=this.images[0];
              this.order.cancel=this.orderDetail[j].cancel_bit;
              this.order.status_id=this.orderDetail[j].status_id;
              this.allProduct.push(this.order);
            }
          }
        }
      },
      err=>{
        this.login=11;
      }
    )
    }


  }

  // cancel the order of user.

  cancelOrder(item){
    if(confirm("Are you sure to cancel Order No. "+item.orderId)){
      let data={
        "order_id":item.orderId,
        "product_id":item.product_id
      }
      this._orderService.cancelOrder(data)
      .subscribe(
        res=>{
          this.allProduct.find(product=>product.product_id==item.product_id && product.orderId==item.orderId).cancel=1;
        }
      )
    }
    
  }

  // Redirects the login page so user can see the orders

  goToLogin(){
    this._router.navigate(['login']);
  }

  // Redirect to home page for shopping

  goToHome(){
    this._router.navigate(['']);
  }
}
