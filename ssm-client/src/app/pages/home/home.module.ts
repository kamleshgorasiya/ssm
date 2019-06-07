import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HomepageComponent } from './homepage/homepage.component';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [HomepageComponent],
  imports: [
    CommonModule,
    RouterModule
  ]
})
export class HomeModule { }
