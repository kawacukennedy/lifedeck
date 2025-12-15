import { Controller, Get, Post, Body, Patch, Param, UseGuards, Request } from '@nestjs/common';
import { CardsService } from './cards.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('cards')
@UseGuards(JwtAuthGuard)
export class CardsController {
  constructor(private readonly cardsService: CardsService) {}

  @Get('daily')
  getDailyCards(@Request() req) {
    return this.cardsService.findDailyCards(req.user.id);
  }

  @Post()
  create(@Body() createCardDto: any) {
    return this.cardsService.createCard(createCardDto);
  }

  @Patch(':id/complete')
  completeCard(@Param('id') id: string, @Request() req) {
    return this.cardsService.completeCard(id, req.user.id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateData: any) {
    return this.cardsService.updateCard(id, updateData);
  }
}