import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CartDetailComponent } from './cart-detail.component';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from 'src/app/core/data/header-setter';
import { RouterTestingModule } from '@angular/router/testing';

describe('CartDetailComponent', () => {
  let component: CartDetailComponent;
  let fixture: ComponentFixture<CartDetailComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CartDetailComponent ],
      imports:[HttpClientTestingModule,RouterTestingModule],
      providers:[HeaderSetter]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CartDetailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should get data of products of cart',()=>{
    component.ngOnInit();
    expect(component.cartData).not.toBeNull();
  });

  it('should prepare the final data to displayed to user if user having product in cart',()=>{
    component.ngOnInit();
    expect(component.allProduct.length).toBeGreaterThan(0);
  });
});
