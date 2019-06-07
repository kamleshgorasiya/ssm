import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { WishlistComponent } from './wishlist/wishlist.component';

@NgModule({
  declarations: [WishlistComponent],
  imports: [
    CommonModule
  ],
  exports:[WishlistComponent]
})
export class WishlistModule { }
