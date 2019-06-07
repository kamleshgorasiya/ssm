import { TestBed,async,inject } from '@angular/core/testing';

import { OrderService } from './order.service';
import { HttpTestingController, HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from '../data/header-setter';

describe('OrderService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, OrderService],
    (orderService: OrderService) => {
      expect(orderService).toBeTruthy();
  })));
});
