import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ManageOrderComponent } from './manage-order/manage-order.component';
import { PendingOrderComponent } from './pending-order/pending-order.component';
import { ConfirmedOrderComponent } from './confirmed-order/confirmed-order.component';
import { DispatchedOrderComponent } from './dispatched-order/dispatched-order.component';
import { DeliveredOrderComponent } from './delivered-order/delivered-order.component';

@NgModule({
  declarations: [ManageOrderComponent, PendingOrderComponent, ConfirmedOrderComponent, DispatchedOrderComponent, DeliveredOrderComponent],
  imports: [
    CommonModule
  ]
})
export class ManageOrderModule { }
