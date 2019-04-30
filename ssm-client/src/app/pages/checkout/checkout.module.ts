import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AddressComponent } from './address/address.component';
import { AddAddressComponent } from './add-address/add-address.component';
import { FormsModule } from '@angular/forms';
import { PaymentComponent } from './payment/payment.component';
import { RouterModule } from '@angular/router';
import { OrderDetailComponent } from './order-detail/order-detail.component';

@NgModule({
  declarations: [AddressComponent, AddAddressComponent, PaymentComponent, OrderDetailComponent],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class CheckoutModule { }
